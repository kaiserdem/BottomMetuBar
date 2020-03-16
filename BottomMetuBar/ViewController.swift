//
//  ViewController.swift
//  BottomMetuBar
//
//  Created by Kaiserdem on 15.03.2020.
//  Copyright © 2020 Kaiserdem. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  enum CardState {
    case expanded
    case collapsed
  }
  
  var cardViewController: CardViewController!
  var visualeEffectView: UIVisualEffectView!
  
  let cardHeight: CGFloat = 500
  let cardHandleAreaHeight: CGFloat = 65
  
  var cardVisible = false
  var nextState: CardState {
    return cardVisible ? .collapsed : .expanded
  }
  
  var runningAnimations = [UIViewPropertyAnimator]()
  var animationProgressWhetInterrupted: CGFloat = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCard()
  }

  func setupCard() {
    visualeEffectView = UIVisualEffectView()
    visualeEffectView.frame = self.view.frame
    self.view.addSubview(visualeEffectView)
    
    cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
    self.addChild(cardViewController)
    self.view.addSubview(cardViewController.view)
    
    cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
    
    cardViewController.view.clipsToBounds = true
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognizer:)))
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
    
    cardViewController.handleArea.addGestureRecognizer(tapGesture)
    cardViewController.handleArea.addGestureRecognizer(panGesture)

  }
  
  @objc func handleCardTap(recognizer:UITapGestureRecognizer) {
    switch recognizer.state {
    case .ended:
      animateTransitionIfNeeded(state: nextState, duration: 1)
    default:
      break
    }
  }
  
  @objc func handleCardPan(recognizer:UIPanGestureRecognizer) {
    
    switch recognizer.state {
    case .began:
      // start transition
      startInteractiveTransition(state: nextState, duration: 1)
    case .changed:
    // update transition
      let translation = recognizer.translation(in: self.cardViewController.handleArea)
      var fractionComplate = translation.y / cardHeight
      fractionComplate = cardVisible ? fractionComplate : -fractionComplate
      updateInteractiveTransition(fractionCompeted: fractionComplate)
    case .ended:
    // continue transition
      continueInteractiveTransition()
    default:
      break
    }
  }
  
  func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
    if runningAnimations.isEmpty {
      let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        
        switch state {
        case .expanded:
          self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
          
        case .collapsed:
          self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
        }
      }
      
      frameAnimator.addCompletion { _ in
        self.cardVisible = !self.cardVisible
        self.runningAnimations.removeAll()
      }
      
      frameAnimator.startAnimation()
      runningAnimations.append(frameAnimator)
      
      let cornerRadiusAnimator  = UIViewPropertyAnimator(duration: duration, curve: .linear) {
        switch state {
        case .expanded:
          self.cardViewController.view.layer.cornerRadius = 10
          
        case .collapsed:
          self.cardViewController.view.layer.cornerRadius = 0
        }
      }
      cornerRadiusAnimator.startAnimation()
      runningAnimations.append(cornerRadiusAnimator)

      let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        switch state {
        case .expanded:
          self.visualeEffectView.effect = UIBlurEffect(style: .dark)

        case .collapsed:
          self.visualeEffectView.effect = nil
        }
      }
      blurAnimator.startAnimation()
      runningAnimations.append(blurAnimator)
    }
  }  
  
  func startInteractiveTransition(state: CardState, duration: TimeInterval) {
    if runningAnimations.isEmpty {
      // run animations
      animateTransitionIfNeeded(state: state, duration: duration)
    }
    for animator in runningAnimations {
        animator.pauseAnimation()
        animationProgressWhetInterrupted = animator.fractionComplete
    }
  }
  
  func updateInteractiveTransition(fractionCompeted: CGFloat) {
    for animator in runningAnimations {
      animator.fractionComplete = fractionCompeted +
      animationProgressWhetInterrupted
    }
  }
  
  func continueInteractiveTransition() {
    for animator in runningAnimations {
      animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
  }
  
  @IBAction func relationGoalsBtnAction(_ sender: UIButton) {
    
      print("relationGoalsBtnAction")

      startInteractiveTransition(state: nextState, duration: 1)
  }

}

