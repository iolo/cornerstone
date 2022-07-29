Cornerstone Client
--------------------

## Introduction

    Cornerstone-Client is a client-side library for interacting with the Cornerstone API.
    It is designed to be used in a Node.js environment.

## Installation

```bash
npm install @day1co/cornerstone-client
```

## Usage

```js
import { Client } from '@day1co/cornerstone-client';
import { FastBus } from '@day1co/fastbus';

const logger = LoggerFactory.getLogger('my-logger');
const bus = new FastBus({}, BusType.LOCAL);
const client = new Client({logger, bus});

const updateEnrollmentState = client.getStub('updateEnrollmentState');
const message = {state: 'NORMAL'};
updateEnrollmentState(message);
```

## Roadmap

* [ ] Add support for subscribing to requested job result
* [ ] Add support for interacting with the Admin API

---
May the **source** be with you