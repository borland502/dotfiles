#!/usr/bin/env bash

# sqlcl function that makes use of the encrypted environment variables to log into the server

sqlv() {
    command sql -S "$USERNAME_LONG/$VLAB_DB_PASSWORD@jdbc:oracle:thin:@$VLAB_DB_HOST:1521:dte3" @"$1"
}