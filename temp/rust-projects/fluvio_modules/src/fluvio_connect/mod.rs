use fluvio::Fluvio;
pub async fn connect_fl() -> Fluvio {
    match Fluvio::connect().await {
        Ok(fluvio) => fluvio,
        Err(err) => {
            eprintln!("failed to connect to Fluvio: {}", err);
            std::process::exit(1);
        }
    }
}
