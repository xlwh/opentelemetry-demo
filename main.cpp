#include <iostream>

#include "opentelemetry/trace/provider.h"
#include "opentelemetry/exporters/ostream/span_exporter.h"
#include "opentelemetry/sdk/trace/processor.h"
#include "opentelemetry/sdk/trace/simple_processor.h"

//namespace alias used in sample code here.
namespace sdktrace   = opentelemetry::sdk::trace;
namespace trace     = opentelemetry::trace;
namespace nostd     = opentelemetry::nostd;

int main() {
    // logging exporter
    auto exporter =
            std::unique_ptr<sdktrace::SpanExporter>(new opentelemetry::exporter::trace::OStreamSpanExporter);
    auto processor = std::unique_ptr<sdktrace::SpanProcessor>(
            new sdktrace::SimpleSpanProcessor(std::move(exporter)));
    auto provider = opentelemetry::trace::Provider::GetTracerProvider();
    auto tracer = provider->GetTracer("foo_library", "1.0.0");


    auto span = tracer->StartSpan("HandleRequest");
    span->AddEvent("cout");
    std::cout << "Hello, World!" << std::endl;
    span->End();

    return 0;
}
