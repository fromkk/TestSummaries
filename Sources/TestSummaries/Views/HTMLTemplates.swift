//
//  HTMLTemplates.swift
//  TestSummaries
//
//  Created by Kazuya Ueoka on 2018/04/24.
//

import Foundation

struct HTMLTemplates {
    
    static let html: String = """
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css" integrity="sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4" crossorigin="anonymous">

    <style type="text/css">

    body {
        background-color: ${backgroundColor};
        color: ${textColor};
    }
    
    .attachments {
        width: auto;
        height: 680px;
        overflow: scroll;
    }

    .attachments td {
        text-align: center;
    }
    
    .attachments img {
        width: auto;
        height: 600px;
    }
    
    </style>

    <title>Test Summary</title>
  </head>
  <body>
    <div class="container">
        <h1>Test summary</h1>

        <h2>Attachments</h2>

${attachments}
        
    </div>

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js" integrity="sha384-cs/chFZiN24E4KMATLdqdvsezGxaGsi4hLGOzlXwp5UZB1LY//20VyM2taTB4QvJ" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js" integrity="sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm" crossorigin="anonymous"></script>
  </body>
</html>
"""
    
    static let attachments: String = """
        <h3>${filename}</h3>

        <div class="attachments">
            <table class="table">
                <tbody>
${attachmentItem}
                    
                </tbody>
            </table>
        </div>

"""
    
    static let attachmentItem: String = """
                    <td>
                        <img src="${path}/Attachments/${fileName}" alt="${fileName}"><br />
                        ${title}
                    </td>
"""
    
}
