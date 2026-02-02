public with sharing class StringListTest {
    public static List<String> generateStringList(Integer strCount){
        List<String> stringList = new List<String>();
        Integer count = 0;
        while(count < strCount) {
            stringList.add('Test ' + count);
            count++;
        }
        return stringList;
    }
}