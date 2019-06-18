# OpenRegister CI/CD pipelines

## Auth

```
fly -t cd-register login -c https://cd.gds-reliability.engineering -n register
```

## Setting pipelines

```
fly -t cd-register set-pipeline --pipeline NAME --config FILE.yaml
```

