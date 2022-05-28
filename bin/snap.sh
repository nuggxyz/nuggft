#!/bin/bash

forge clean && forge snapshot --force --optimize --optimizer-runs 1000000 -v
