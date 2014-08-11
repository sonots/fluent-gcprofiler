# fluent-gcprofiler

Using fluent-gcprofiler, you can start and stop [GC::Profiler](http://docs.ruby-lang.org/ja/2.1.0/class/GC=3a=3aProfiler.html) dynamically from outside of fluentd without any configuration changes.

## Installation

```
$ fluent-gem install fluent-gcprofiler
```

## Prerequisite

`in_debug_agent` plugin is required to be enabled.

```
<source>
  type debug_agent
</source>
```

GC::Profiler is a ruby built-in profiler, you do not need to install another gem.

## Usage

Start

```
$ fluent-gcprofiler start
```

Stop and write a profiling result.

```
$ fluent-gcprofiler stop -o /tmp/fluent-gcprofiler.txt
```

## Options

|parameter|description|default|
|---|---|---|
|-h, --host HOST|fluent host|127.0.0.1|
|-p, --port PORT|debug_agent|24230|
|-u, --unix PATH|use unix socket instead of tcp||
|-o, --output PATH|output file|/tmp/fluent-gcprofiler.txt|

## Sample Output

`/tmp/fluent-gcprofiler.txt` as default:

```
GC 21 invokes.
Index    Invoke Time(sec)       Use Size(byte)     Total Size(byte)         Total Object                    GC Time(ms)
    1               0.452               722640              1668720                83436         5.05216200000002046977
    2               0.458               722600              1668720                83436         3.76476800000001832203
```

## ChangeLog

See [CHANGELOG.md](./CHANGELOG.md)

## Contributing

1. Fork it ( http://github.com/sonots/fluent-gcprofiler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

See [LICENSE.txt](./LICENSE.txt)
