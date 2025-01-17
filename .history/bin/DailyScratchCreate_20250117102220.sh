cci org scratch dev DailyWork

cci flow run dev_org --org DailyWork

echo "Scratch org named DailyWork successfully created."

cci task run dx --command "force:user:permset:assign --perm-set-name Change_History_Admin" --org DailyWork

echo "Change History Admin permission set successfully assigned."

cci org browser --org DailyWork