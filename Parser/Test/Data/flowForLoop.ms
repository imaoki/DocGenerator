/* for_loop */
for i = 1 to 10 do expr

for i = 1 to 10 do (
  expr
  continue
  exit with expr
)

for i in source do (
  expr
)

for i = 10 to 1 by -1 where expr while expr do (
  expr
)

for i = 10 to 1 by -1 where expr while expr collect (
  expr
)
