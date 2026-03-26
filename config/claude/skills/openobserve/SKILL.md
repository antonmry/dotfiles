# OpenObserve Dashboard API

How to create and manage dashboards in OpenObserve via the REST API.

## Authentication

All requests require Basic auth:

```
Authorization: Basic <base64(email:password)>
```

## API Endpoints

| Action | Method | Endpoint |
|--------|--------|----------|
| List   | GET    | `/api/{org}/dashboards` |
| Get    | GET    | `/api/{org}/dashboards/{id}` |
| Create | POST   | `/api/{org}/dashboards` |
| Update | PUT    | `/api/{org}/dashboards/{id}?hash={hash}` |
| Delete | DELETE | `/api/{org}/dashboards/{id}` |

The default org is `default`.

## Gotcha: Hash Required for Updates

The `PUT` endpoint requires the current dashboard hash as a **query parameter** (not in the body). Always fetch the dashboard first to get the latest hash:

```bash
HASH=$(curl -s -H "Authorization: ..." \
  "http://localhost:5080/api/default/dashboards/{id}" | jq -r '.hash')

curl -X PUT "http://localhost:5080/api/default/dashboards/{id}?hash=$HASH" ...
```

If you omit the hash or send a stale one, the API returns an error about missing/invalid hash.

## Dashboard JSON Structure (v8)

The API accepts and returns a v8 format. When creating, send the inner object; the API wraps it. When updating, send the `.v8` portion of the GET response.

```json
{
  "title": "My Dashboard",
  "description": "...",
  "tabs": [
    {
      "tabId": "overview",
      "name": "Overview",
      "panels": [ ... ]
    }
  ]
}
```

## Panel Structure

Every panel requires these fields. Omitting any causes a deserialization error:

```json
{
  "id": "unique_panel_id",
  "type": "bar",
  "title": "Panel Title",
  "description": "",
  "queryType": "promql",
  "config": { "show_legends": true },
  "queries": [ ... ],
  "layout": { "x": 0, "y": 0, "w": 12, "h": 4, "i": 1 }
}
```

### Panel types

`line`, `bar`, `table`, `area`, `stacked`, `metric`, `pie`, `donut`, `heatmap`, `h-bar`, `scatter`, `gauge`, `sankey`.

### Query types

- `promql` -- for metrics streams
- `sql` -- for logs and traces streams

## Gotcha: PanelFilter Format

The `filter` field inside `queries[].fields` is an untagged enum. It must be:

```json
{
  "filterType": "group",
  "logicalOperator": "AND",
  "conditions": []
}
```

An empty array `[]`, `null`, or a plain object without `filterType` will fail deserialization.

## Metrics Panels (PromQL)

For metrics, use `queryType: "promql"` with `customQuery: true`:

```json
{
  "query": "sum by (session_id) (claude_code_cost_usage)",
  "customQuery": true,
  "config": { "promql_legend": "" },
  "fields": {
    "stream": "claude_code_cost_usage",
    "stream_type": "metrics",
    "x": [],
    "y": [],
    "filter": { "filterType": "group", "logicalOperator": "AND", "conditions": [] }
  }
}
```

### Gotcha: Legend Interpolation

Setting `promql_legend` to `"\{{label_name}}"` does **not** interpolate via the API. The `\{{...}}` syntax renders literally. Leave `promql_legend` empty (`""`) to let OpenObserve auto-generate legends from the metric labels. The auto-generated format is verbose (`{"label":"value",...}`) but functional.

### Gotcha: Claude Code Exports Metrics and Logs Only

Claude Code does **not** export traces. Set `OTEL_METRICS_EXPORTER=otlp` and `OTEL_LOGS_EXPORTER=otlp`. Setting `OTEL_TRACES_EXPORTER` has no effect.

## SQL Panels (Logs / Traces)

For logs and traces, use `queryType: "sql"`.

### Gotcha: Field Bindings Required for Charts

Even with `customQuery: true`, the `x` and `y` arrays **must** have entries or the chart shows "Please select required fields to render the chart". Populate them:

```json
"x": [{"label": "Timestamp", "alias": "x_axis_1", "column": "_timestamp",
       "color": null, "aggregationFunction": "histogram"}],
"y": [{"label": "Count", "alias": "y_axis_1", "column": "_timestamp",
       "color": "#5960b2", "aggregationFunction": "count"}]
```

### Builder mode (preferred for simple queries)

Set `customQuery: false` and configure `x`, `y`, and `filter` fields. OpenObserve generates the SQL automatically:

```json
{
  "query": "",
  "customQuery": false,
  "fields": {
    "stream": "default",
    "stream_type": "traces",
    "x": [{"label": "Timestamp", "alias": "x_axis_1", "column": "_timestamp",
           "color": null, "aggregationFunction": "histogram"}],
    "y": [{"label": "Avg Duration", "alias": "y_axis_1", "column": "duration",
           "color": "#5960b2", "aggregationFunction": "avg"}],
    "filter": { ... }
  }
}
```

### Gotcha: String Fields Need CAST

Some trace fields (e.g. `row_count`) are stored as strings. Using `SUM(row_count)` fails with a type error. Use `SUM(CAST(row_count AS BIGINT))` in custom SQL.

## Layout

The layout grid is managed by the OpenObserve frontend (vue-grid-layout). Values set via the API are often rendered at incorrect sizes. **Workaround**: create panels via the API with any layout values, then resize them manually in the UI. The UI normalizes the grid correctly.

## Workflow Summary

1. **Create** the dashboard via `POST` with panels, queries, and field bindings.
2. **Resize** panels in the OpenObserve UI (layout values from the API are unreliable).
3. **Update** queries via `PUT` using the `?hash=` query param. Always fetch the latest hash first.
4. **Avoid** updating layout via the API after UI resizing -- the UI-managed layout will break.

## OTLP Endpoint Configuration

OpenObserve requires the org in the OTLP base URL. The SDK appends `/v1/metrics`, `/v1/logs`, etc:

```
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:5080/api/default
```

Without `/api/default`, requests hit `/v1/metrics` which returns 404.

### gRPC vs HTTP

Both work (gRPC on port 5081, HTTP on port 5080). HTTP (`http/protobuf`) is easier to debug since you can see requests in OpenObserve access logs.
