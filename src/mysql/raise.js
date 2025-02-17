import raise from "@8v/raise";

class MySqlError extends Error {}

export default raise(MySqlError);
