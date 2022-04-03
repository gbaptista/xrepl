# xrepl

Some tweaks on top of Fennel standard REPL.

<div align="center">
  <img alt="xrepl example" src="https://raw.githubusercontent.com/gbaptista/assets/main/xrepl/xrepl-b.png" width="60%">
</div>

## Installing

To install through [fnx](https://github.com/gbaptista/fnx), add to your `.fnx.fnl`:

```fnl
:xrepl {:fennel/fnx {:git/github "gbaptista/xrepl"}}

; Example:

{:name    "my-project"
 :version "0.0.1"

 :dependencies {
   :xrepl {:fennel/fnx {:git/github "gbaptista/xrepl"}}}}
```

And install:
```
fnx dep install
```

## Usage

```fnl
(let [xrepl (require :xrepl)] (xrepl {:data data}))

(let [xrepl (require :xrepl)] (xrepl))
```
