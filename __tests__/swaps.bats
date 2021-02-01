
#!/usr/bin/env bats

load bats.global.bash

@test "100 random swaps and withdraw all" {
  symbols="ABC"
  ac_balance=$(cleos get currency balance lptoken.sx liquidity.sx AC)
  ab_balance=$(cleos get currency balance lptoken.sx liquidity.sx AB)
  bc_balance=$(cleos get currency balance lptoken.sx liquidity.sx BC)

  for i in {0..100}
  do
    rnd=$((RANDOM % 10000))
    curr1="${symbols:$(( RANDOM % ${#symbols} )):1}"
    decimals=$((RANDOM % 10000))
    if [[ "$curr1" = "C" ]]
    then
      decimals=$((RANDOM % 10000))8$((RANDOM % 10000))
    fi
    curr2=$curr1
    until [ $curr2 != $curr1 ]
    do
      curr2="${symbols:$(( RANDOM % ${#symbols} )):1}"
    done
    tokens="$rnd.$decimals $curr1"
    echo "swapping $tokens => $curr2"
    run cleos transfer myaccount curve.sx "$tokens" "$curr2"
    [ $status -eq 0 ]
  done

  run cleos transfer liquidity.sx curve.sx "$ac_balance" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[1].liquidity.quantity')
  [ "$result" = "0.000000000 AC" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[1].reserve0.quantity')
  [ "$result" = "0.0000 A" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[1].reserve1.quantity')
  [ "$result" = "0.000000000 C" ]

  run cleos transfer liquidity.sx curve.sx "$ab_balance" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[0].liquidity.quantity')
  [ "$result" = "0.0000 AB" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[0].reserve0.quantity')
  [ "$result" = "0.0000 A" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[0].reserve1.quantity')
  [ "$result" = "0.0000 B" ]

  run cleos transfer liquidity.sx curve.sx "$bc_balance" "" --contract lptoken.sx
  [ $status -eq 0 ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[2].liquidity.quantity')
  [ "$result" = "0.000000000 BC" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[2].reserve0.quantity')
  [ "$result" = "0.0000 B" ]
  result=$(cleos get table curve.sx curve.sx pairs | jq -r '.rows[2].reserve1.quantity')
  [ "$result" = "0.000000000 C" ]
}
