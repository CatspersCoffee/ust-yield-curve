#lang racket/base

(require gregor
         net/url
         racket/cmdline
         racket/port
         threading)

(define all (make-parameter #f))

(define curve-date (make-parameter (today)))

(command-line
 #:program "racket extract.rkt"
 #:once-each
 [("-a" "--all") "Download all available yield curve data"
                (all #t)]
 [("-d" "--date") d
                  "Download yield curve for specific date (overridden if downloading all)"
                  (curve-date (iso8601->date d))])

(call-with-output-file (string-append "/var/tmp/ust/yield-curve/" (~t (curve-date) "yyyy-MM-dd") ".xml")
  (λ (out) (~> (if (all)
                   "https://data.treasury.gov/feed.svc/DailyTreasuryYieldCurveRateData"
                   (string-append "https://data.treasury.gov/feed.svc/DailyTreasuryYieldCurveRateData"
                                  "?$filter=day(NEW_DATE) eq " (number->string (->day (curve-date))) " and "
                                  "month(NEW_DATE) eq " (number->string (->month (curve-date))) " and "
                                  "year(NEW_DATE) eq " (number->string (->year (curve-date)))))
               (string->url _)
               (get-pure-port _)
               (copy-port _ out)))
  #:exists 'replace)
