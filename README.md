# slimy
[![Build Status](https://travis-ci.org/lessonly/slimy.svg?branch=main)](https://travis-ci.org/lessonly/slimy)

SLI middleware for rack.  Most monitoring instrumentation is organized around Golden Signals, USE, RED, etc.  The goal of this library is to provide direct measurement useful for determining SLIs, SLOs and error budgets.
## What is a Service Level Indicator (SLI)?

This is a concept we learned from the [Google SRE BOOK (free)](https://sre.google/sre-book/service-level-objectives/).  Simply put this is a measure of (good event) / (total events).  Ideally this should measure of how the system is meeting user expectations.

### Example

Maybe your target for your homepage is to respond to requests within 50 milliseconds.


* If you get 100 requests and all responses are then your SLI value is 100/100 (100%)
* If you get 100 requests and 5 of the responses are errors and 5 of them take 100ms then your SLI value is 90/100 (90%)

## What is a Service Level Objective (SLO)?

An SLO is an SLI with some threshold you're trying to meet.

In the homepage example above, that would be a high visiblity, high importance page so maybe you want 99.95% of requests to meet your success criteria.

Maybe you have report that is fast for some customers, and slow for others.  The slow customers don't need the data urgently and everybody is happy so you might be happy with 90% of reports being generated in 120 seconds.

This allows us to define error budgets and gives us a firm framework for prioritizing feature work vs performance issues that can often be seen as a "Nice to have" until it becomes an "Ooops this is functionally not working."



[Error Budgets](https://sre.google/sre-book/embracing-risk/#xref_risk-management_unreliability-budgets)


## SLAs?

Service Level Agreements are contracts with external teams.  They're not unrelated but a bit beyond the scope of the goal here.

## SLIs and other types of Monitoring

There are many ways to monitoring running systems.  Golden Signals, RED, USE, are all important frameworks for monitoring and analyzing the health of a running system.  SLOs are 


