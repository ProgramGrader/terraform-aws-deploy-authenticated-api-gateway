package lambdas

class Person {

    lateinit var name: String

    fun setName(name: String): lambdas.Person {
        this.name = name
        return this
    }
    //getName was taken by some JVM library
    fun acquireName() : String  { return name}



    //getName() was taken by some JVM library
}