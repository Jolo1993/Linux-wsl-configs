use fluvio::metadata::topic::TopicSpec;
use crate::fluvio_connect::{connect_fl};

pub async  fn create_topic(topic_name: &str, partitions: u32, replicas: u32) {
// Create a topic
    let admin = connect_fl().await.admin().await;
    let topic_spec = TopicSpec::new_computed(partitions, replicas, None);
    match admin.create(topic_name.to_string(), false, topic_spec).await {
        Ok(_) => {}
        Err(_) => {}
    }
}
