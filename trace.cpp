//
// Created by zhb on 2022/4/5.
//

#include "trace.h"

Tracer::Tracer(opentelemetry::nostd::string_view service_name) {
    init(service_name);
}

void Tracer::init(opentelemetry::nostd::string_view service_name) {
    if (!tracer) {
        const opentelemetry::exporter::jaeger::JaegerExporterOptions opts;
        auto jaeger_exporter  = std::unique_ptr<opentelemetry::sdk::trace::SpanExporter>(new opentelemetry::exporter::jaeger::JaegerExporter(opts));
        auto processor = std::unique_ptr<opentelemetry::sdk::trace::SpanProcessor>(new opentelemetry::sdk::trace::SimpleSpanProcessor(std::move(jaeger_exporter)));
        const auto jaeger_resource = opentelemetry::sdk::resource::Resource::Create(std::move(opentelemetry::sdk::resource::ResourceAttributes{{"service.name", service_name}}));
        const auto provider = opentelemetry::nostd::shared_ptr<opentelemetry::trace::TracerProvider>(new opentelemetry::sdk::trace::TracerProvider(std::move(processor), jaeger_resource));
        tracer = provider->GetTracer(service_name, OPENTELEMETRY_SDK_VERSION);
    }
}

void Tracer::shutdown() {
    if (tracer) {
        tracer->CloseWithMicroseconds(1);
    }
}

span Tracer::start_trace(opentelemetry::nostd::string_view trace_name) {
    if (is_enabled()) {
        return tracer->StartSpan(trace_name);
    }
    return noop_tracer->StartSpan(trace_name);
}

span Tracer::add_span(opentelemetry::nostd::string_view span_name, const span& parent_span) {
    if (is_enabled() && parent_span) {
        const auto parent_ctx = parent_span->GetContext();
        return add_span(span_name, parent_ctx);
    }
    return noop_tracer->StartSpan(span_name);
}

span Tracer::add_span(opentelemetry::nostd::string_view span_name, const span_context& parent_ctx) {
    if (is_enabled() && parent_ctx.IsValid()) {
        opentelemetry::trace::StartSpanOptions span_opts;
        span_opts.parent = parent_ctx;
        return tracer->StartSpan(span_name, span_opts);
    }
    return noop_tracer->StartSpan(span_name);
}

bool Tracer::is_enabled() const {
    return true;
}
