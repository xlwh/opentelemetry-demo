//
// Created by zhb on 2022/4/5.
//

#ifndef OPENTELEMETRY_DEMO_TRACE_H
#define OPENTELEMETRY_DEMO_TRACE_H

#include "opentelemetry/trace/provider.h"
#include "opentelemetry/sdk/trace/simple_processor.h"
#include "opentelemetry/sdk/trace/tracer_provider.h"

using span = opentelemetry::nostd::shared_ptr<opentelemetry::trace::Span>;
using span_context = opentelemetry::trace::SpanContext;

class Tracer {
private:
    const static opentelemetry::nostd::shared_ptr<opentelemetry::trace::Tracer> noop_tracer;
    opentelemetry::nostd::shared_ptr<opentelemetry::trace::Tracer> tracer;

public:
    Tracer() = default;
    Tracer(opentelemetry::nostd::string_view service_name);

    // Init the tracer.
    void init(opentelemetry::nostd::string_view service_name);
    // Shutdown the tracer.
    void shutdown();

    bool is_enabled() const;

    // Creates and returns a new span with `trace_name`
    // this span represents a trace, since it has no parent.
    span start_trace(opentelemetry::nostd::string_view trace_name);

    // Creates and returns a new span with `span_name` which parent span is `parent_span'.
    span add_span(opentelemetry::nostd::string_view span_name, const span& parent_span);

    // Creates and return a new span with `span_name`
    // the span is added to the trace which it's context is `parent_ctx`.
    // parent_ctx contains the required information of the trace.
    span add_span(opentelemetry::nostd::string_view span_name, const span_context& parent_ctx);
};

#endif //OPENTELEMETRY_DEMO_TRACE_H
