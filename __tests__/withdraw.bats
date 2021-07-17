
#!/usr/bin/env bats


@test "withdraw fake token" {
  run cleos transfer liquidity.sx curve.sx "1000.0000 AB" "" --contract fake.token
  echo "$output"
  [ $status -eq 1 ]
  [[ "$output" =~ "invalid extended symbol" ]]
}

@test "withdraw all" {
  cab_balance=$(cleos get currency balance lptoken.sx liquidity.sx CAB)

  run cleos transfer liquidity.sx curve.sx "$cab_balance" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[4].liquidity.quantity')
  [ "$result" = "0.000000000 CAB" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[4].reserve0.quantity')
  [ "$result" = "0.0000 AB" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[4].reserve1.quantity')
  [ "$result" = "0.000000000 C" ]

  ac_balance=$(cleos get currency balance lptoken.sx liquidity.sx AC)

  run cleos transfer liquidity.sx curve.sx "$ac_balance" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[1].liquidity.quantity')
  [ "$result" = "0.000000000 AC" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[1].reserve0.quantity')
  [ "$result" = "0.0000 A" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[1].reserve1.quantity')
  [ "$result" = "0.000000000 C" ]

  ab_balance1=$(cleos get currency balance lptoken.sx liquidity.sx AB)
  ab_balance2=$(cleos get currency balance lptoken.sx myaccount AB)
  ab_balance3=$(cleos get currency balance lptoken.sx fee.sx AB)

  run cleos transfer liquidity.sx curve.sx "$ab_balance1" "" --contract lptoken.sx
  run cleos transfer myaccount curve.sx "$ab_balance2" "" --contract lptoken.sx
  run cleos transfer fee.sx curve.sx "$ab_balance3" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[0].liquidity.quantity')
  [ "$result" = "0.0000 AB" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[0].reserve0.quantity')
  [ "$result" = "0.0000 A" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[0].reserve1.quantity')
  [ "$result" = "0.0000 B" ]

  bc_balance=$(cleos get currency balance lptoken.sx liquidity.sx BC)

  run cleos transfer liquidity.sx curve.sx "$bc_balance" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[2].liquidity.quantity')
  [ "$result" = "0.000000000 BC" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[2].reserve0.quantity')
  [ "$result" = "0.0000 B" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[2].reserve1.quantity')
  [ "$result" = "0.000000000 C" ]

  de_balance=$(cleos get currency balance lptoken.sx liquidity.sx DE)

  run cleos transfer liquidity.sx curve.sx "$de_balance" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[3].liquidity.quantity')
  [ "$result" = "0.000000 DE" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[3].reserve0.quantity')
  [ "$result" = "0.000000 D" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[3].reserve1.quantity')
  [ "$result" = "0.000000 E" ]

}

@test "remove pairs" {

  run cleos push action curve.sx removepair '["AB"]' -p curve.sx
  echo "Output: $output"
  [ $status -eq 0 ]

  run cleos push action curve.sx removepair '["AC"]' -p curve.sx
  echo "Output: $output"
  [ $status -eq 0 ]

  run cleos push action curve.sx removepair '["BC"]' -p curve.sx
  echo "Output: $output"
  [ $status -eq 0 ]

  run cleos push action curve.sx removepair '["CAB"]' -p curve.sx
  echo "Output: $output"
  [ $status -eq 0 ]

  run cleos push action curve.sx removepair '["DE"]' -p curve.sx
  echo "Output: $output"
  [ $status -eq 0 ]

  run cleos push action curve.sx removepair '["AD"]' -p curve.sx
  echo "Output: $output"
  [[ "$output" =~ "does not exist" ]]
  [ $status -eq 1 ]
}
