#include <iostream>

#include "opentelemetry/sdk/trace/simple_processor.h"
#include "opentelemetry/sdk/trace/tracer_provider.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/exporters/ostream/span_exporter.h"

namespace trace_api = opentelemetry::trace;
namespace trace_sdk = opentelemetry::sdk::trace;
namespace nostd     = opentelemetry::nostd;
namespace
{
    void initTracer()
    {
        auto exporter = std::unique_ptr<trace_sdk::SpanExporter>(
                new opentelemetry::exporter::trace::OStreamSpanExporter);
        auto processor = std::unique_ptr<trace_sdk::SpanProcessor>(
                new trace_sdk::SimpleSpanProcessor(std::move(exporter)));
        auto provider = nostd::shared_ptr<trace_api::TracerProvider>(
                new trace_sdk::TracerProvider(std::move(processor)));

        // Set the global trace provider
        trace_api::Provider::SetTracerProvider(provider);
    }
}  // namespace

int main() {
    initTracer();

    std::cout << "Hello, World!" << std::endl;
    return 0;
}
