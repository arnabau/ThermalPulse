//
//  Icons+SVG.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/19/26.
//

import Foundation
import SwiftUI

struct LinkedIn: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.85938*width, y: 0.10938*height))
        path.addCurve(to: CGPoint(x: 0.89063*width, y: 0.14063*height), control1: CGPoint(x: 0.87666*width, y: 0.10938*height), control2: CGPoint(x: 0.89063*width, y: 0.12334*height))
        path.addLine(to: CGPoint(x: 0.89063*width, y: 0.85938*height))
        path.addCurve(to: CGPoint(x: 0.85938*width, y: 0.89063*height), control1: CGPoint(x: 0.89063*width, y: 0.87666*height), control2: CGPoint(x: 0.87666*width, y: 0.89063*height))
        path.addLine(to: CGPoint(x: 0.14063*width, y: 0.89063*height))
        path.addCurve(to: CGPoint(x: 0.10938*width, y: 0.85938*height), control1: CGPoint(x: 0.12334*width, y: 0.89063*height), control2: CGPoint(x: 0.10938*width, y: 0.87666*height))
        path.addLine(to: CGPoint(x: 0.10938*width, y: 0.14063*height))
        path.addCurve(to: CGPoint(x: 0.14063*width, y: 0.10938*height), control1: CGPoint(x: 0.10938*width, y: 0.12334*height), control2: CGPoint(x: 0.12334*width, y: 0.10938*height))
        path.addLine(to: CGPoint(x: 0.85938*width, y: 0.10938*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.34111*width, y: 0.7751*height))
        path.addLine(to: CGPoint(x: 0.34111*width, y: 0.40225*height))
        path.addLine(to: CGPoint(x: 0.2252*width, y: 0.40225*height))
        path.addLine(to: CGPoint(x: 0.2252*width, y: 0.7751*height))
        path.addLine(to: CGPoint(x: 0.34111*width, y: 0.7751*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.2832*width, y: 0.35127*height))
        path.addCurve(to: CGPoint(x: 0.35039*width, y: 0.28408*height), control1: CGPoint(x: 0.32021*width, y: 0.35127*height), control2: CGPoint(x: 0.35029*width, y: 0.32119*height))
        path.addCurve(to: CGPoint(x: 0.2832*width, y: 0.21689*height), control1: CGPoint(x: 0.35039*width, y: 0.24698*height), control2: CGPoint(x: 0.32031*width, y: 0.21689*height))
        path.addCurve(to: CGPoint(x: 0.21602*width, y: 0.28408*height), control1: CGPoint(x: 0.2461*width, y: 0.21689*height), control2: CGPoint(x: 0.21602*width, y: 0.24698*height))
        path.addCurve(to: CGPoint(x: 0.2832*width, y: 0.35127*height), control1: CGPoint(x: 0.21602*width, y: 0.32119*height), control2: CGPoint(x: 0.2461*width, y: 0.35127*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.7751*width, y: 0.7751*height))
        path.addLine(to: CGPoint(x: 0.7751*width, y: 0.57061*height))
        path.addCurve(to: CGPoint(x: 0.63613*width, y: 0.39297*height), control1: CGPoint(x: 0.7751*width, y: 0.47021*height), control2: CGPoint(x: 0.75352*width, y: 0.39297*height))
        path.addCurve(to: CGPoint(x: 0.52646*width, y: 0.45322*height), control1: CGPoint(x: 0.57969*width, y: 0.39297*height), control2: CGPoint(x: 0.54189*width, y: 0.42393*height))
        path.addLine(to: CGPoint(x: 0.5249*width, y: 0.45322*height))
        path.addLine(to: CGPoint(x: 0.5249*width, y: 0.40225*height))
        path.addLine(to: CGPoint(x: 0.41377*width, y: 0.40225*height))
        path.addLine(to: CGPoint(x: 0.41377*width, y: 0.7751*height))
        path.addLine(to: CGPoint(x: 0.52949*width, y: 0.7751*height))
        path.addLine(to: CGPoint(x: 0.52949*width, y: 0.59062*height))
        path.addCurve(to: CGPoint(x: 0.59902*width, y: 0.49492*height), control1: CGPoint(x: 0.52949*width, y: 0.54199*height), control2: CGPoint(x: 0.53877*width, y: 0.49492*height))
        path.addCurve(to: CGPoint(x: 0.65928*width, y: 0.59375*height), control1: CGPoint(x: 0.6585*width, y: 0.49492*height), control2: CGPoint(x: 0.65928*width, y: 0.55049*height))
        path.addLine(to: CGPoint(x: 0.65928*width, y: 0.7751*height))
        path.addLine(to: CGPoint(x: 0.7751*width, y: 0.7751*height))
        path.closeSubpath()
        return path
    }
}

struct GitHub: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.49961*width, y: 0.07451*height))
        path.addCurve(to: CGPoint(x: 0.93662*width, y: 0.51133*height), control1: CGPoint(x: 0.74092*width, y: 0.07451*height), control2: CGPoint(x: 0.93662*width, y: 0.26992*height))
        path.addCurve(to: CGPoint(x: 0.63916*width, y: 0.92549*height), control1: CGPoint(x: 0.93662*width, y: 0.70381*height), control2: CGPoint(x: 0.81211*width, y: 0.86719*height))
        path.addCurve(to: CGPoint(x: 0.62451*width, y: 0.90801*height), control1: CGPoint(x: 0.62451*width, y: 0.92549*height), control2: CGPoint(x: 0.62529*width, y: 0.9168*height))
        path.addLine(to: CGPoint(x: 0.62451*width, y: 0.79814*height))
        path.addCurve(to: CGPoint(x: 0.5873*width, y: 0.70928*height), control1: CGPoint(x: 0.62454*width, y: 0.76473*height), control2: CGPoint(x: 0.61113*width, y: 0.73271*height))
        path.addCurve(to: CGPoint(x: 0.78262*width, y: 0.50137*height), control1: CGPoint(x: 0.725*width, y: 0.68506*height), control2: CGPoint(x: 0.78262*width, y: 0.60117*height))
        path.addCurve(to: CGPoint(x: 0.73486*width, y: 0.37217*height), control1: CGPoint(x: 0.78262*width, y: 0.45293*height), control2: CGPoint(x: 0.7665*width, y: 0.40811*height))
        path.addCurve(to: CGPoint(x: 0.72949*width, y: 0.25693*height), control1: CGPoint(x: 0.75361*width, y: 0.31387*height), control2: CGPoint(x: 0.73232*width, y: 0.26445*height))
        path.addCurve(to: CGPoint(x: 0.61104*width, y: 0.2998*height), control1: CGPoint(x: 0.67676*width, y: 0.25215*height), control2: CGPoint(x: 0.62207*width, y: 0.29141*height))
        path.addCurve(to: CGPoint(x: 0.5002*width, y: 0.28623*height), control1: CGPoint(x: 0.57852*width, y: 0.29102*height), control2: CGPoint(x: 0.5416*width, y: 0.28623*height))
        path.addCurve(to: CGPoint(x: 0.38994*width, y: 0.29951*height), control1: CGPoint(x: 0.45898*width, y: 0.28623*height), control2: CGPoint(x: 0.42217*width, y: 0.29082*height))
        path.addCurve(to: CGPoint(x: 0.26963*width, y: 0.25527*height), control1: CGPoint(x: 0.38535*width, y: 0.2959*height), control2: CGPoint(x: 0.32637*width, y: 0.2502*height))
        path.addCurve(to: CGPoint(x: 0.26484*width, y: 0.37246*height), control1: CGPoint(x: 0.2667*width, y: 0.26279*height), control2: CGPoint(x: 0.24492*width, y: 0.31338*height))
        path.addCurve(to: CGPoint(x: 0.21768*width, y: 0.50107*height), control1: CGPoint(x: 0.23359*width, y: 0.4083*height), control2: CGPoint(x: 0.21768*width, y: 0.45273*height))
        path.addCurve(to: CGPoint(x: 0.41221*width, y: 0.70908*height), control1: CGPoint(x: 0.21768*width, y: 0.60068*height), control2: CGPoint(x: 0.2749*width, y: 0.68447*height))
        path.addCurve(to: CGPoint(x: 0.37832*width, y: 0.76846*height), control1: CGPoint(x: 0.3958*width, y: 0.725*height), control2: CGPoint(x: 0.38389*width, y: 0.74551*height))
        path.addCurve(to: CGPoint(x: 0.27676*width, y: 0.74307*height), control1: CGPoint(x: 0.35283*width, y: 0.7748*height), control2: CGPoint(x: 0.30254*width, y: 0.78125*height))
        path.addCurve(to: CGPoint(x: 0.18018*width, y: 0.68652*height), control1: CGPoint(x: 0.24111*width, y: 0.69043*height), control2: CGPoint(x: 0.21035*width, y: 0.671*height))
        path.addCurve(to: CGPoint(x: 0.22793*width, y: 0.73965*height), control1: CGPoint(x: 0.16748*width, y: 0.70117*height), control2: CGPoint(x: 0.20996*width, y: 0.70898*height))
        path.addCurve(to: CGPoint(x: 0.37471*width, y: 0.82646*height), control1: CGPoint(x: 0.23682*width, y: 0.7543*height), control2: CGPoint(x: 0.24219*width, y: 0.84199*height))
        path.addLine(to: CGPoint(x: 0.37471*width, y: 0.90215*height))
        path.addCurve(to: CGPoint(x: 0.35527*width, y: 0.92383*height), control1: CGPoint(x: 0.37471*width, y: 0.91328*height), control2: CGPoint(x: 0.37822*width, y: 0.92959*height))
        path.addCurve(to: CGPoint(x: 0.0625*width, y: 0.51123*height), control1: CGPoint(x: 0.18486*width, y: 0.86426*height), control2: CGPoint(x: 0.0625*width, y: 0.70205*height))
        path.addCurve(to: CGPoint(x: 0.49961*width, y: 0.07451*height), control1: CGPoint(x: 0.0625*width, y: 0.26992*height), control2: CGPoint(x: 0.25811*width, y: 0.07441*height))
        path.closeSubpath()
        return path
    }
}

struct xTwitter: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.79883*width, y: 0.78125*height))
        path.addLine(to: CGPoint(x: 0.48644*width, y: 0.32592*height))
        path.addLine(to: CGPoint(x: 0.48697*width, y: 0.32635*height))
        path.addLine(to: CGPoint(x: 0.76864*width, y: 0))
        path.addLine(to: CGPoint(x: 0.67451*width, y: 0))
        path.addLine(to: CGPoint(x: 0.44506*width, y: 0.26563*height))
        path.addLine(to: CGPoint(x: 0.26284*width, y: 0))
        path.addLine(to: CGPoint(x: 0.01598*width, y: 0))
        path.addLine(to: CGPoint(x: 0.30763*width, y: 0.42511*height))
        path.addLine(to: CGPoint(x: 0.3076*width, y: 0.42507*height))
        path.addLine(to: CGPoint(x: 0, y: 0.78125*height))
        path.addLine(to: CGPoint(x: 0.09413*width, y: 0.78125*height))
        path.addLine(to: CGPoint(x: 0.34923*width, y: 0.48572*height))
        path.addLine(to: CGPoint(x: 0.55197*width, y: 0.78125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.22555*width, y: 0.07102*height))
        path.addLine(to: CGPoint(x: 0.66385*width, y: 0.71023*height))
        path.addLine(to: CGPoint(x: 0.58926*width, y: 0.71023*height))
        path.addLine(to: CGPoint(x: 0.1506*width, y: 0.07102*height))
        path.closeSubpath()
        return path
    }
}

struct Instagram: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0.36982*height))
        path.addCurve(to: CGPoint(x: 0.63018*width, y: 0.5*height), control1: CGPoint(x: 0.57168*width, y: 0.36982*height), control2: CGPoint(x: 0.63018*width, y: 0.42832*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.63018*height), control1: CGPoint(x: 0.63018*width, y: 0.57168*height), control2: CGPoint(x: 0.57168*width, y: 0.63018*height))
        path.addCurve(to: CGPoint(x: 0.36982*width, y: 0.5*height), control1: CGPoint(x: 0.42832*width, y: 0.63018*height), control2: CGPoint(x: 0.36982*width, y: 0.57168*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.36982*height), control1: CGPoint(x: 0.36982*width, y: 0.42832*height), control2: CGPoint(x: 0.42832*width, y: 0.36982*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.89043*width, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.88789*width, y: 0.66113*height), control1: CGPoint(x: 0.89043*width, y: 0.55391*height), control2: CGPoint(x: 0.89102*width, y: 0.60732*height))
        path.addCurve(to: CGPoint(x: 0.8249*width, y: 0.8248*height), control1: CGPoint(x: 0.88486*width, y: 0.72363*height), control2: CGPoint(x: 0.8707*width, y: 0.779*height))
        path.addCurve(to: CGPoint(x: 0.66123*width, y: 0.88779*height), control1: CGPoint(x: 0.7792*width, y: 0.87051*height), control2: CGPoint(x: 0.72373*width, y: 0.88477*height))
        path.addCurve(to: CGPoint(x: 0.5001*width, y: 0.89033*height), control1: CGPoint(x: 0.60742*width, y: 0.89082*height), control2: CGPoint(x: 0.554*width, y: 0.89033*height))
        path.addCurve(to: CGPoint(x: 0.33896*width, y: 0.88779*height), control1: CGPoint(x: 0.44629*width, y: 0.89033*height), control2: CGPoint(x: 0.39287*width, y: 0.89082*height))
        path.addCurve(to: CGPoint(x: 0.17529*width, y: 0.8248*height), control1: CGPoint(x: 0.27646*width, y: 0.88477*height), control2: CGPoint(x: 0.22109*width, y: 0.87061*height))
        path.addCurve(to: CGPoint(x: 0.1123*width, y: 0.66113*height), control1: CGPoint(x: 0.12959*width, y: 0.7791*height), control2: CGPoint(x: 0.11533*width, y: 0.72363*height))
        path.addCurve(to: CGPoint(x: 0.10977*width, y: 0.5*height), control1: CGPoint(x: 0.10928*width, y: 0.60732*height), control2: CGPoint(x: 0.10977*width, y: 0.55381*height))
        path.addCurve(to: CGPoint(x: 0.1123*width, y: 0.33887*height), control1: CGPoint(x: 0.10977*width, y: 0.44619*height), control2: CGPoint(x: 0.10928*width, y: 0.39277*height))
        path.addCurve(to: CGPoint(x: 0.17529*width, y: 0.1752*height), control1: CGPoint(x: 0.11533*width, y: 0.27637*height), control2: CGPoint(x: 0.12949*width, y: 0.221*height))
        path.addCurve(to: CGPoint(x: 0.33896*width, y: 0.11221*height), control1: CGPoint(x: 0.221*width, y: 0.12949*height), control2: CGPoint(x: 0.27646*width, y: 0.11523*height))
        path.addCurve(to: CGPoint(x: 0.5001*width, y: 0.10967*height), control1: CGPoint(x: 0.39277*width, y: 0.10918*height), control2: CGPoint(x: 0.44619*width, y: 0.10967*height))
        path.addCurve(to: CGPoint(x: 0.66123*width, y: 0.11221*height), control1: CGPoint(x: 0.55391*width, y: 0.10967*height), control2: CGPoint(x: 0.60732*width, y: 0.10918*height))
        path.addCurve(to: CGPoint(x: 0.8249*width, y: 0.1752*height), control1: CGPoint(x: 0.72373*width, y: 0.11523*height), control2: CGPoint(x: 0.7791*width, y: 0.12939*height))
        path.addCurve(to: CGPoint(x: 0.88789*width, y: 0.33887*height), control1: CGPoint(x: 0.87061*width, y: 0.2209*height), control2: CGPoint(x: 0.88486*width, y: 0.27637*height))
        path.addCurve(to: CGPoint(x: 0.89043*width, y: 0.5*height), control1: CGPoint(x: 0.89092*width, y: 0.39268*height), control2: CGPoint(x: 0.89043*width, y: 0.44609*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.70029*height))
        path.addCurve(to: CGPoint(x: 0.70029*width, y: 0.5*height), control1: CGPoint(x: 0.61084*width, y: 0.70029*height), control2: CGPoint(x: 0.70029*width, y: 0.61084*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.29971*height), control1: CGPoint(x: 0.70029*width, y: 0.38916*height), control2: CGPoint(x: 0.61084*width, y: 0.29971*height))
        path.addCurve(to: CGPoint(x: 0.29971*width, y: 0.5*height), control1: CGPoint(x: 0.38916*width, y: 0.29971*height), control2: CGPoint(x: 0.29971*width, y: 0.38916*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.70029*height), control1: CGPoint(x: 0.29971*width, y: 0.61084*height), control2: CGPoint(x: 0.38916*width, y: 0.70029*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.7085*width, y: 0.33828*height))
        path.addCurve(to: CGPoint(x: 0.74159*width, y: 0.3246*height), control1: CGPoint(x: 0.72091*width, y: 0.3383*height), control2: CGPoint(x: 0.73281*width, y: 0.33337*height))
        path.addCurve(to: CGPoint(x: 0.75527*width, y: 0.2915*height), control1: CGPoint(x: 0.75037*width, y: 0.31582*height), control2: CGPoint(x: 0.75529*width, y: 0.30391*height))
        path.addCurve(to: CGPoint(x: 0.7085*width, y: 0.24473*height), control1: CGPoint(x: 0.75527*width, y: 0.26563*height), control2: CGPoint(x: 0.73438*width, y: 0.24473*height))
        path.addCurve(to: CGPoint(x: 0.66172*width, y: 0.2915*height), control1: CGPoint(x: 0.68262*width, y: 0.24473*height), control2: CGPoint(x: 0.66172*width, y: 0.26563*height))
        path.addCurve(to: CGPoint(x: 0.7085*width, y: 0.33828*height), control1: CGPoint(x: 0.66172*width, y: 0.31738*height), control2: CGPoint(x: 0.68262*width, y: 0.33828*height))
        path.closeSubpath()
        return path
    }
}
