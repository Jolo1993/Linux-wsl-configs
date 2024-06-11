use fluvio::RecordKey;

pub async fn pub_write(topic_name: &str, record: String ) {
// Produce to a topic
    let producer = fluvio::producer(topic_name).await.unwrap();
    producer.send(RecordKey::NULL, record).await.unwrap();
    // Fluvio batches outgoing records by default, so flush producer to ensure all records are sent
    producer.flush().await.unwrap();
}