//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Vicki Tan on 2/20/16.
//  Copyright © 2016 Vicki Tan. All rights reserved.
//

import UIKit

enum MessageState {
    case beginPanRight
    case willArchive
    case willDelete
    case beginPanLeft
    case willLater
    case willList
    case defaultState
}

class MailboxViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageView: UIImageView!
    @IBOutlet weak var messageParentView: UIView!
    @IBOutlet weak var listIconView: UIImageView!
    @IBOutlet weak var laterIconView: UIImageView!
    @IBOutlet weak var deleteIconView: UIImageView!
    @IBOutlet weak var archiveIconView: UIImageView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var listView: UIImageView!
    @IBOutlet weak var rescheduleView: UIImageView!
    
    var messageOriginalCenter: CGPoint!
    var currentMessageState: MessageState!
    
    func fadeInIcon(icon: UIView) {
        UIView.animateWithDuration(0.2) { () -> Void in
            icon.alpha = 1
        
        }
    }
    
    func fadeOutIcon(icon: UIView) {
        UIView.animateWithDuration(0.2) { () -> Void in
            icon.alpha = 0
        }
    }
    
    func setBackgroundColor(color: UIColor) {
            self.messageParentView.backgroundColor = color
    }
    
    func hideIcons() {
        archiveIconView.alpha = 0
        deleteIconView.alpha = 0
        laterIconView.alpha = 0
        listIconView.alpha = 0
    }
    
    func iconPosition(offset: CGFloat, side: String) -> CGFloat {
        if side == "left" {
            if offset < 60 {
                return 20.0
            } else {
                return offset - 40.0
            }
        } else {
            if offset > -60 {
                return 280.0
            } else {
                return messageView.frame.width + offset + 20.0
            }
        }
    }
    
    func iconOpacity (offset: CGFloat) -> CGFloat {
        let absoffset = abs(offset)
        if absoffset <= 60 {
            return absoffset/60
        } else {
            return 1
        }
    }
    
    func setMessageState(state: MessageState) {
        if state != currentMessageState {
            hideIcons()
            switch state {
            case .beginPanRight:
                fadeInIcon(archiveIconView)
                setBackgroundColor(UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1))
            case .willArchive:
                fadeInIcon(archiveIconView)
                setBackgroundColor(UIColor(red: 112/255, green: 217/255, blue: 98/255, alpha: 1))
            case .willDelete:
                fadeInIcon(deleteIconView)
                setBackgroundColor(UIColor(red: 235/255, green: 84/255, blue: 51/255, alpha: 1))
            case .beginPanLeft:
                fadeInIcon(laterIconView)
                setBackgroundColor(UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1))
            case .willLater:
                fadeInIcon(laterIconView)
                setBackgroundColor(UIColor(red: 250/255, green: 210/255, blue: 51/255, alpha: 1))
            case .willList:
                fadeInIcon(listIconView)
                setBackgroundColor(UIColor(red: 216/255, green: 166/255, blue: 117/255, alpha: 1))
            case .defaultState:
                setBackgroundColor(UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1))
            }
            currentMessageState = state
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 320, height: 1222)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func motionEnded(motion: ., withEvent event: UIEvent) {
//        if motion == .MotionShake {
//            self.messageView.frame.origin.x = 0
//            delay(0.3, closure: { () -> () in
//                UIView.animateWithDuration(0.2, animations: { () -> Void in
//                    self.feedView.frame.origin.y = 0
//                }
//            )}
//        )}
//    }
    

    @IBAction func didPan(sender: AnyObject) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        let offset = messageView.center.x - view.center.x
    
        if sender.state == UIGestureRecognizerState.Began {
            messageOriginalCenter = messageView.center
        
        } else if sender.state == UIGestureRecognizerState.Changed {
            messageView.center = CGPoint(x: messageOriginalCenter.x + translation.x, y: messageOriginalCenter.y)
        
            switch offset {
            case 0...60:
                setMessageState(.beginPanRight)
                archiveIconView.frame.origin.x = iconPosition(offset, side: "left")
                archiveIconView.alpha = iconOpacity(offset)
            case 61...240:
                setMessageState(.willArchive)
                archiveIconView.frame.origin.x = iconPosition(offset, side: "left")
            case 241...320:
                setMessageState(.willDelete)
                deleteIconView.frame.origin.x = iconPosition(offset, side: "left")
            case -60...0:
                setMessageState(.beginPanLeft)
                laterIconView.frame.origin.x = iconPosition(offset, side: "right")
                laterIconView.alpha = iconOpacity(offset)
            case (-240)...(-61):
                setMessageState(.willLater)
                laterIconView.frame.origin.x = iconPosition(offset, side: "right")
            case (-320)...(-241):
                setMessageState(.willList)
                listIconView.frame.origin.x = iconPosition(offset, side: "right")
            default:
                setMessageState(.defaultState)
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            if let state = currentMessageState {
                switch state {
                    
                case .beginPanRight:
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageView.frame.origin.x = 0
                    })
                case .willArchive, .willDelete:
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageView.frame.origin.x = self.view.frame.width
                        self.hideIcons()
                        delay(0.3, closure: { () -> () in
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.feedView.frame.origin.y = 0
                            })
                        })
                    })
                case .willLater:
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageView.frame.origin.x = 0 - self.view.frame.width
                        self.rescheduleView.alpha = 1
                        self.hideIcons()
                    })
                case .willList:
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.listView.alpha = 1
                    })
                case .beginPanLeft:
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageView.frame.origin.x = 0
                    })
                    
                default:
                    break
                    
                }
            }
        }
    }
    
    @IBAction func didTap(sender: AnyObject) {
        UIView.animateWithDuration(0.2) { () -> Void in
            self.rescheduleView.alpha = 0
        delay(0.3, closure: { () -> () in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.feedView.frame.origin.y = 0
            })
        })
    }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
