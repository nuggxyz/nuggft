#!/bin/bash

forge clean && forge snapshot --force --optimize --optimize-runs 1000000 -v
