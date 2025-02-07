cci org scratch dev DailyWorkAHTest

cci flow run dev_org --org DailyWorkAHTest

echo "Scratch org named DailyWorkAHTest successfully created."

cci task run dx --command "force:user:permset:assign --perm-set-name SIMS" --org DailyWorkAHTest

echo "SIMS permission set successfully assigned."

cci task run load_dataset -o mapping datasets/mapping.yml --org DailyWorkAHTest

echo "Data loaded successfully."

cci org browser --org DailyWorkAHTest