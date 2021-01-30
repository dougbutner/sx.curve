#!/usr/bin/env bats

@test "maintenance" {
  run cleos transfer myaccount curve.sx "1000.0000 A" ""
  echo "Output: $output"
  [ $status -eq 1 ]
  [[ "$output" =~ "maintenance" ]]
}

@test "set config" {
  run cleos push action curve.sx setconfig '[["ok", 4, 0, "fee.sx"]]' -p curve.sx
  echo "Output: $output"
  [ $status -eq 0 ]
}

@test "config.status = ok" {
  result=$(cleos get table curve.sx curve.sx config | jq -r '.rows[0].status')
  echo $result
  [ $result = "ok" ]
}
