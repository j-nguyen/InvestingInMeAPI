//
//  main.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-04-03.
//

import Vapor

let drop = Drop

drop.get("/") { request in
  return drop.view.make("index")
}

drop.run()
