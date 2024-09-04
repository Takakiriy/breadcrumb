# shell script breadcrumb

This shows breadcrumb in shell script and continues from middle of shell script.

## How to use

- Copy functions `PushBreadcrumb` .. `EscapeRegularExpression` to your shell script.
- Support your shell script `--start-at`, `--step` and `--step-after` option .

## Output example

    #breadcrumb: 0000-00-00T00:00:00.000000000+0000 (PID=1111)  >> Main
    #breadcrumb: 0000-00-00T00:00:00.000000000+0000 (PID=1111)  >> Main >> Example1
    Do in Example1
    #breadcrumb: 0000-00-00T00:00:00.000000000+0000 (PID=1111)  >> Main >> Example1 (end)
    #breadcrumb: 0000-00-00T00:00:00.000000000+0000 (PID=1111)  >> Main >> Example2
    Do in Example2
    #breadcrumb: 0000-00-00T00:00:00.000000000+0000 (PID=1111)  >> Main >> Example2 (end)
    #breadcrumb: 0000-00-00T00:00:00.000000000+0000 (PID=1111)  >> Main (end)

# test

See [README.yaml](./README.yaml).
