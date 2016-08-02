extern crate postgres;
extern crate hyper;
extern crate regex;
extern crate rustc_serialize;
extern crate lettre;

use postgres::{Connection, SslMode};
use std::io::Read;
use hyper::Client;
use regex::Regex;
use rustc_serialize::json;
use std::collections::HashMap;
use std::process::Command;

#[derive(RustcDecodable)]
struct Stock {
    t: String,
    l_cur: String,
    lt: String,
}

fn main() {
    let dsn = "postgresql://webtech:webtech@shuboshakuro.de/finance";
    let mut fetch_url: String = "http://finance.google.com/finance/info?client=ig&q=".to_owned();

    let connection = match Connection::connect(dsn, SslMode::None) {
        Ok(conn) => conn,
        Err(e) => {
            println!("Connection error: {}", e);
            return;
        }
    };

    let stmt = connection.prepare("SELECT \"shortName\" FROM \"stocks\"").unwrap();

    for row in stmt.query(&[]).unwrap().iter() {
        let short_name: String = row.get(0);
        fetch_url.push_str(&short_name);
        fetch_url.push_str(",");
    }
    fetch_url.pop();

    println!("{:?}", fetch_url);

    let client = Client::new();

    let mut response = match client.get(&fetch_url).send() {
        Ok(response) => response,
        Err(_) => panic!("Request failed!")
    };

    let mut buffer = String::new();
    match response.read_to_string(&mut buffer) {
        Ok(_) => (),
        Err(_) => panic!("Read Request failed!")
    };

    let re = Regex::new(r"\{(?s).*?\}").unwrap();

    connection.execute("CREATE TABLE IF NOT EXISTS stock_values (
        id serial primary key,
        shortname varchar(5),
        value real,
        t varchar
    )", &[]);

    let stmt = connection.prepare(
        "INSERT INTO stock_values (shortName, value, t)
        VALUES ($1, $2, $3)
    ").unwrap();


    let mut last_values = HashMap::new();
    for obj in re.captures_iter(&buffer) {
        let stock: Stock = json::decode(obj.at(0).unwrap_or("")).unwrap();
        let value: f32 = match stock.l_cur.parse::<f32>() {
            Ok(val) => val,
            Err(_) => 0.00,
        };
        stmt.execute(&[&stock.t, &value, &stock.lt]).expect("Inserting failed");

        last_values.insert(stock.t, value);
    }

    let stmt = connection
        .prepare("SELECT \"bLimit\", \"tLimit\", \"username\", \"shortName\", \"bActive\", \"tActive\" FROM \"user_stocks\"").unwrap();
    let stmt_mail = connection
        .prepare("SELECT \"email\", \"notification\" FROM \"users\" WHERE \"username\"=$1").unwrap();

    for row in stmt.query(&[]).unwrap().iter() {
        let b_limit: String = row.get(0);
        let b_limit: f32 = match b_limit.parse::<f32>() {
            Ok(val) => val,
            Err(_) => -1.0,
        };
        let t_limit: String = row.get(1);
        let t_limit: f32 = match t_limit.parse::<f32>() {
            Ok(val) => val,
            Err(_) => -1.0,
        };
        let username: String = row.get(2);
        let shortname: String = row.get(3);

        let b_active: bool = row.get(4);
        let t_active: bool = row.get(5);

        let mut notif: bool = false;
        let mut mail: String = String::from("");;
        for row in stmt_mail.query(&[&username]).unwrap().iter() {
            notif = row.get(1);
            mail = row.get(0);
        }

        if notif == true {
            match last_values.get(&shortname) {
                Some(&val) => check_and_send_mail(b_limit, t_limit, b_active, t_active, val, shortname, mail),
                _ => println!("Don't have Stock."),
            }
        }
    }

}

fn check_and_send_mail(b_limit: f32, t_limit: f32, b_active: bool, t_active: bool, val: f32, shortname: String, mail_address: String) {
    if (b_active && (b_limit > val)) || (t_active && (t_limit < val)) {
        Command::new("fmail.py")
                .arg(mail_address)
                .arg(shortname)
                .arg(b_limit.to_string())
                .arg(t_limit.to_string())
                .arg(val.to_string())
                .current_dir("/usr/local/bin")
                .spawn().expect("Mail-Script don't want to start :(!");
    }
}
