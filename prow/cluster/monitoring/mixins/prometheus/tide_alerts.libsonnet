{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'Tide progress',
        rules: [
          {
            alert: 'TideNoProgressKK',
            expr: |||
              clamp_min(
              (sum(merges_sum{org="kubernetes",repo="kubernetes",branch="master"}) or vector(0))
               - (sum(merges_sum{org="kubernetes",repo="kubernetes",branch="master"} offset 5m ) or vector(0)),
              0) < 0.5
              and
              (avg(pooledprs{branch="master",org="kubernetes",repo="kubernetes"} and ((time() - updatetime) < 240))  or vector(0)) > 0.5
            |||,
            'for': '4h',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Tide has not merged any PRs in kubernetes/kubernetes:master in the past 4 hours despite PRs in the pool. See the <https://prow.k8s.io/tide-history?repo=kubernetes%2Fkubernetes&branch=master|tide-history> page for k/k:m.',
            },
          },
          {
            alert: 'TideSyncLoopDuration',
            expr: |||
              avg_over_time(syncdur{job="tide"}[15m]) > 120
            |||,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'The Tide sync controllers loop period has averaged more than 2 minutes for the last 15 mins. See the <https://monitoring.prow.k8s.io/d/d69a91f76d8110d3e72885ee5ce8038e/tide-dashboard?orgId=1&from=now-24h&to=now&fullscreen&panelId=7|processing time graph>.',
            },
          },
          {
            alert: 'TideStatusUpdateLoopDuration',
            expr: |||
              avg_over_time(statusupdatedur{job="tide"}[15m]) > 120
            |||,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'The Tide status update controllers loop period has averaged more than 2 minutes for the last 15 mins. See the <https://monitoring.prow.k8s.io/d/d69a91f76d8110d3e72885ee5ce8038e/tide-dashboard?orgId=1&from=now-24h&to=now&fullscreen&panelId=7|processing time graph>.',
            },
          },
          {
            alert: 'TidePoolErrorRateIndividual',
            expr: |||
              (max(sum(increase(tidepoolerrors[10m])) by (org, repo, branch)) or vector(0)) >= 3
            |||,
            'for': '5m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'At least one Tide pool encountered 3+ sync errors in a 10 minute window. If the TidePoolErrorRateMultiple alert has not fired this is likely an isolated configuration issue. See the <https://prow.k8s.io/tide-history|/tide-history> page and the <https://monitoring.prow.k8s.io/d/d69a91f76d8110d3e72885ee5ce8038e/tide-dashboard?orgId=1&fullscreen&panelId=6&from=now-24h&to=now|sync error graph>.',
            },
          },
          {
            alert: 'TidePoolErrorRateMultiple',
            expr: |||
              (count(sum(increase(tidepoolerrors[10m])) by (org, repo) >= 3) or vector(0)) >= 3
            |||,
            'for': '5m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Tide encountered 3+ sync errors in a 10 minute window in at least 3 different repos that it handles. See the <https://prow.k8s.io/tide-history|tide-history> page and the <https://monitoring.prow.k8s.io/d/d69a91f76d8110d3e72885ee5ce8038e/tide-dashboard?orgId=1&fullscreen&panelId=6&from=now-24h&to=now|sync error graph>.',
            },
          },
        ],
      },
    ],
  },
}