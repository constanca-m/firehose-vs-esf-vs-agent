Issue: https://github.com/elastic/obs-infraobs-team/issues/1337.

Currently, this repository is only for situation:

```mermaid
flowchart LR
    cloudwatch[Cloudwatch Logs] --> firehose[Firehose]
    firehose[Firehose] --> elastic[Elastic Cloud]
```