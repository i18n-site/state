import raise from "@8v/raise";

class WarnError extends Error {}

export default raise(WarnError);
