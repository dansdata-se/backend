drop user if exists :"USERNAME";

create user :"USERNAME"
with
  password :'PASSWORD';

alter role :"USERNAME"
set
  search_path = "$user",
  public,
  extensions,
  dance_api_public;
