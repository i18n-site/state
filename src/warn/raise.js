import raise from "@8v/raise";

class warnError extends Error {}

export default raise(warnError);
