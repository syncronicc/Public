export type config={
	deep_service_search:boolean;
}

return table.freeze({--- Read-Only and before modifying read the side comments!
	deep_service_search=false;
}::config)