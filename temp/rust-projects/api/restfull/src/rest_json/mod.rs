pub async fn api_get_json(url: &str) -> Result<serde_json::Value,reqwest::Error> {
    let request_url = url;
    let response = reqwest::get(&*request_url).await?;
    let json = response.json().await?;
    println!("{:?}", json);
    Ok(json)
}

pub async api_post_json(){

}

pub async api_put_json(){

}

pub async api_delete_json(){

}