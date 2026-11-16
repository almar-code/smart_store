// عرض الرقم بحد اقصى 99+
String badgeCount(int count, {int max = 99}) => count > max ? '$max+' : '$count';