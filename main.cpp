#include <iostream>

#include "tracer.h"

int main() {
    std::unique_ptr<Tracer> tracer = std::make_unique<Tracer>("demo");
    auto span = tracer->start_trace("demo");
    tracer->add_span("cout", span);
    std::cout << "Hello, World!" << std::endl;
    tracer->shutdown();
    return 0;
}
