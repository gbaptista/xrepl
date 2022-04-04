(local sn (require :supernova))

(local xrepl {})

(fn xrepl.extract-from [debug-fn scope]
  (local to-bind {})
  (var done? false)
  (var index 1)

  (while (and scope (not done?))
    (local (success key value) (pcall debug-fn scope index))
    (if (not success)
      (set done? true)
      (if (not= key nil)
       (when (not (string.find key "^%(")) (tset to-bind key value))
       (set done? true)))
    (set index (+ index 1)))
  to-bind)

(fn xrepl.scope-fn-at [index]
  (let [info (debug.getinfo index :f)]
    (when info (. info :func))))

(fn xrepl.extract []
  (local keys [])
  (local to-bind {})

  (var i 1)
  (while (< i 100)
    (each [key value (pairs (xrepl.extract-from debug.getlocal i))]
      (when (= (. to-bind key) nil) (table.insert keys key))
      (tset to-bind key value))
    (each [key value (pairs (xrepl.extract-from debug.getupvalue (xrepl.scope-fn-at i)))]
      (when (= (. to-bind key) nil) (table.insert keys key))
      (tset to-bind key value))
    (set i (+ i 1)))
  to-bind)

(fn xrepl.relevant-source? [source]
  (and
    (> source.line 0) 
    (or (string.find source.short-path "%.fnl$")
        (string.find source.short-path "%.lua$"))
    (not (string.find source.short-path "xrepl%.fnl$"))))

(fn xrepl.reverse [list]
  (let [result []]
    (var i (length list))
    (while (> i 0)
      (table.insert result (. list i))
      (set i (- i 1)))
    result))

(fn xrepl.traceback []
  (local sources [])
  (var i 1)
  (while (< i 10)
    (let [info (debug.getinfo i)]
      (if info
        (let [source { :short-path info.short_src :line info.currentline}]
          (when (xrepl.relevant-source? source) (table.insert sources source))
          (set i (+ i 1)))
        (set i (+ 1 1000)))))
  (xrepl.reverse sources))

(fn xrepl.print-source! [source]
  (print (.. (sn.yellow source.short-path) ":" (sn.cyan source.line))))

(fn xrepl.bind! [?to-bind]
  (let [fennel        (require :fennel)
        original-repl fennel.repl
        env           _G
        to-bind       (or ?to-bind {})]

    (set debug.traceback fennel.traceback)

    (each [key value (pairs (xrepl.extract))] (tset env key value))

    (each [key value (pairs to-bind)] (tset env key value))

    (each [_ source (pairs (xrepl.traceback))]
      (xrepl.print-source! source))

    (original-repl {:env env})))

xrepl.bind!
