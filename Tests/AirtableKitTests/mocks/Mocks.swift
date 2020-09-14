import Foundation

// TODO: remove when we start using swift 5.3 toolchain

enum Mocks {
    static let multipleRecords: String = """
    {
        "records": [
            {
                "id": "rec123",
                "fields": {
                    "name": "john",
                    "bool": true,
                    "multi": ["abc", "xyz"],
                    "dbl": 3.5,
                },
                "createdTime": "2020-01-01T20:45:17.000Z",
            },
            {
                "id": "recPm9",
                "fields": {
                    "name": "mark",
                },
                "createdTime": "2018-01-19T20:52:07.000Z",
            }
        ]
    }
    """
    
    static let singleRecord: String = """
    {
        "id": "rec9jki",
        "fields": {
            "email": "jane.doe@example.com",
            "users": ["rachel", "chelsea"],
            "file": [
                {
                    "id": "flp6tr5",
                    "url": "https://dropbox.com/xyz",
                    "filename": "secret.jpg",
                },
            ],
            "many": [
                {
                    "id": "attdc4R",
                    "url": "https://dropbox.com/123",
                    "custom_field": 3.95,
                },
                {
                    "id": "attCG6D",
                    "url": "https://dropbox.com/rst",
                    "filename": "screenshot.png",
                },
            ]
        },
        "createdTime": "2019-12-12T15:32:43.000Z",
    }
    """
    
    static let singleRecordDelete: String = """
    {
        "id": "rec2yKtdiltjPFu8g",
        "deleted": true
    }
    """
    
    static let singleRecordDeleteFail: String = """
    {
        "id": "rec2yKtdiltjPFu8g",
        "deleted": false
    }
    """
    
    static let multipleRecordsDelete: String = """
    {
        "records": [
            {
                "id": "rec1",
                "deleted": true
            },
            {
                "id": "rec2",
                "deleted": true
            },
            {
                "id": "rec3",
                "deleted": true
            }
        ]
    }
    """
    
}
