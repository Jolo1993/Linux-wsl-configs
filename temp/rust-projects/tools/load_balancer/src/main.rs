use async_trait::async_trait;
use pingora::prelude::*;
use std::sync::Arc;


pub struct LB(Arc<LoadBalancer<RoundRobin>>);


fn main() {
    let mut my_server = Server::new(None).unwrap();
    my_server.bootstrap();
    my_server.run_forever();
}
