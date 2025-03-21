load_env:
	set -o allexport; source .env.test; set +o allexport;

run_act: load_env
	act -j terraform