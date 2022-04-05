#include <iostream>

#include "opentelemetry/trace/provider.h"

int main() {
    auto provider = opentelemetry::trace::Provider::GetTracerProvider();
    auto tracer = provider->GetTracer("foo_library", "1.0.0");

    auto span = tracer->StartSpan("HandleRequest");
    span->AddEvent("cout");
    std::cout << "Hello, World!" << std::endl;
    span->End();

    return 0;
}
