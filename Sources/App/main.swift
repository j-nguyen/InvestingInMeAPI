//
//  main.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-04-03.
//

import Vapor

let drop = Droplet()

drop.get("index") { request in
  return drop.view.make()
}

drop.run()
