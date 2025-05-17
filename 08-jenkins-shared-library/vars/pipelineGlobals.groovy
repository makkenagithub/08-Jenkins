// function to get aws accound of different envs
def getAccountID(String environment){
    switch(environment) { 
        case 'dev': 
            return "315069654700"
        case 'qa':
            return "315069654701"
        case 'uat':
            return "315069654702"
        case 'pre-prod':
            return "315069654703"
        case 'prod':
            return "315069654705"
        default:
            return "nothing"
    } 

}