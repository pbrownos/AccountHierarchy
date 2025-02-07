cci org scratch dev DailyWorkAH

cci flow run dev_org --org DailyWorkAH

echo "Scratch org named DailyWork successfully created."

cci task run dx --command "force:user:permset:assign --perm-set-name SIMSmin" --org DailyWorkAH

echo "SIMS permission set successfully assigned."

cci org browser --org DailyWorkAH