cci org scratch dev DailyWorkAH

cci org default DailyWorkAH

cci flow run dev_org --org DailyWorkAH

echo "Scratch org named DailyWork successfully created."

cci task run dx --command "force:user:permset:assign --perm-set-name SIMS" --org DailyWorkAH

echo "SIMS permission set successfully assigned."

cci task run load_dataset -o mapping datasets/mapping.yml --org DailyWorkAH

echo "Data loaded successfully."

cci org browser --org DailyWorkAH