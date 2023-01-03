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
import { CornerstoneClient } from '@day1co/cornerstone-client';
import { FastBus, BusType } from '@day1co/fastbus';

const logger = LoggerFactory.getLogger('my-logger');
const bus = new FastBus({}, BusType.CLOUD_PUBSUB);
const client = new CornerstoneClient({logger, bus});

const yourTask = client.getStub('your-task-name');
const message = 'message-to-your-task';
yourTask(message);
```

## Roadmap

* [ ] Add support for subscribing to requested job result
* [ ] Add support for interacting with the Admin API

---
May the **source** be with you