> ./conf/mysql.js

export default (ping)=>
  Promise.allSettled Object.entries(mysql).map ping

